<?php

namespace App\Domain\Returns\Controllers;

use App\Domain\Orders\Models\Order;
use App\Domain\Returns\Requests\StoreReturnRequest;
use App\Domain\Returns\Resources\ReturnResource;
use App\Domain\Returns\Services\ReturnService;

class ReturnController
{
    public function __construct(private readonly ReturnService $returnService)
    {
    }

    public function store(StoreReturnRequest $request, Order $order)
    {
        $returnRequest = $this->returnService->request(
            $request->user(),
            $order,
            (string) $request->validated()['reason'],
        );

        return new ReturnResource($returnRequest);
    }
}
